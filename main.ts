import {
  Hono,
  Context,
  Env,
  etag,
  logger,
  create,
  Magika,
  Mime,
  standardTypes,
  otherTypes,
  magikaLabelsTypes,
  fileTypeFromBuffer,
  FileTypeResult,
} from "./deps.ts";

const magika = new Magika();
await magika.load({});
const mime = new Mime(standardTypes, otherTypes);
mime.define(magikaLabelsTypes, true);

const app: Hono<Env, Record<string | number | symbol, never>, "/"> = new Hono();

app.use("*", etag());
app.use("*", logger());

app.get(
  "/",
  (c: Context<Env, "/", Record<string | number | symbol, never>>): Response =>
    c.text("OK!")
);

app.get(
  "/:CID/*",
  async (
    c: Context<Env, "/:CID/*", Record<string | number | symbol, never>>
  ): Promise<Response> => {
    type identifyBytesObject = {
      label: string;
      score: number;
    };
    let data: number[] | null = [];
    let dataArray: Uint8Array | null;
    let stream: AsyncIterable<Uint8Array> | null;
    let identify: identifyBytesObject | FileTypeResult | null;
    try {
      stream = create().cat(c.req.path.replace(/^\//, ""));
      for await (const chunk of stream) {
        data.push(...chunk);
      }
      dataArray = new Uint8Array(data);
      identify = (await magika.identifyBytes(dataArray)) as identifyBytesObject;
      let mimeType: string | null = mime.getType(identify.label);
      if (!mimeType) {
        identify = (await fileTypeFromBuffer(dataArray)) as FileTypeResult;
        mimeType = identify.mime;
      }
      return c.body(dataArray, {
        status: 200,
        headers: {
          ...(mimeType ? { "Content-Type": mimeType } : {}),
          "Accept-Ranges": "bytes",
          "Cache-Control": "public, max-age=315360000",
          Etag: `"${c.req.param("CID")}"`,
          "X-Ipfs-Path": c.req.path,
          "X-Ipfs-Datasize": dataArray.length.toString(),
        },
      });
    } catch (e) {
      return c.body(
        e.response?.statusText ? e.response.statusText : null,
        e.response?.status ? e.response.status : 500
      );
    } finally {
      stream = null;
      data = null;
      dataArray = null;
      identify = null;
    }
  }
);

Deno.serve(app.fetch);
