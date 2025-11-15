// src/middleware/tenant.ts
import { Request, Response, NextFunction } from "express";

export const tenantMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const host = req.headers.host || "";
  let tenantId = "oeo";

  if (host.includes("supermart")) tenantId = "supermart";
  else if (host.includes("equiplease")) tenantId = "equiplease";

  // JWT override
  const token = req.headers.authorization?.split(" ")[1];
  if (token) {
    try {
      const payload = JSON.parse(
        Buffer.from(token.split(".")[1], "base64").toString()
      );
      if (payload.tenantId) tenantId = payload.tenantId;
    } catch {}
  }

  (req as any).tenantId = tenantId;
  next();
};