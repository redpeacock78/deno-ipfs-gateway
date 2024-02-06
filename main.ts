import { Hono, Context, Env } from "npm:hono";
import { fileTypeFromBuffer, FileTypeResult } from "npm:file-type";
import { create } from "https://deno.land/x/ipfs@0.4.0-wip.6/mod.ts";

const app: Hono<Env, Record<string | number | symbol, never>, "/"> = new Hono();

app.get(
  "/",
  (c: Context<Env, "/", Record<string | number | symbol, never>>): Response =>
    c.text("OK!")
);

app.get(
  "/:IPFSPath",
  async (
    c: Context<Env, "/:IPFSPath", Record<string | number | symbol, never>>
  ): Promise<Response> => {
    if (c.req.param("IPFSPath") === "") return c.body(null, 400);
    let data: number[] | null = [];
    let stream: AsyncIterable<Uint8Array> | null;
    try {
      stream = create().cat(c.req.param("IPFSPath"));
      for await (const chunk of stream) {
        data.push(...chunk);
      }
      const fileType: FileTypeResult | undefined = await fileTypeFromBuffer(
        new Uint8Array(data)
      );
      return c.body(new Uint8Array(data), {
        status: 200,
        headers: {
          "Content-Type": fileType!.mime,
          "Cache-Control": "public, max-age=315360000",
        },
      });
    } catch (_e) {
      return c.body(null, 404);
    } finally {
      stream = null;
      data = null;
    }
  }
);

Deno.serve(app.fetch);
