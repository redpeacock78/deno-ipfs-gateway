import { Mime } from "npm:mime@4.0.1";
import { Magika } from "npm:magika@0.2.6";
import { FileTypeResult } from "npm:file-type@19.0.0";
import { fileTypeFromBuffer } from "npm:file-type@19.0.0";
import otherTypes from "npm:mime@4.0.1/types/other.js";
import standardTypes from "npm:mime@4.0.1/types/standard.js";
import magikaLabelsTypes from "./types/magikaLabelsTypes.ts";
import { Hono, Context } from "https://deno.land/x/hono@v4.1.0-rc.1/mod.ts";
import { Env, ToSchema } from "https://deno.land/x/hono@v4.1.0-rc.1/types.ts";
import {
  etag,
  logger,
} from "https://deno.land/x/hono@v4.1.0-rc.1/middleware.ts";
import { create } from "https://deno.land/x/ipfs@0.4.0-wip.6/mod.ts";
export {
  Hono,
  Mime,
  Magika,
  etag,
  logger,
  create,
  fileTypeFromBuffer,
  standardTypes,
  otherTypes,
  magikaLabelsTypes,
};
export type { Context, Env, ToSchema, FileTypeResult };
