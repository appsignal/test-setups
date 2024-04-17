// Next.js API route support: https://nextjs.org/docs/api-routes/introduction
import type { NextApiRequest, NextApiResponse } from "next";
import { setTag } from "@appsignal/nodejs";

type Data = {
  name: string;
};

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse<Data>,
) {
  setTag("lol", "lmao")
  res.status(200).json({ name: "John Doe" });
}
