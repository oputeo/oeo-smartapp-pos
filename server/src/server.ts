import "dotenv/config";
import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import { tenantMiddleware } from "./middleware/tenant.ts";
import posRoutes from "./routes/pos";  // ADD THIS LINE

const app = express();

app.use(cors());
app.use(express.json());
app.use(tenantMiddleware);

// ADD POS ROUTES
app.use("/api/pos", posRoutes);

// Root route
app.get("/", (req: any, res) => {
  res.json({
    msg: "OEO API LIVE",
    port: process.env.PORT,
    tenant: req.tenantId || "unknown",
  });
});

// MongoDB Connection
const MONGO_URI = process.env.MONGO_URI;
if (!MONGO_URI) {
  console.error("ERROR: MONGO_URI missing in .env");
  process.exit(1);
}

mongoose
  .connect(MONGO_URI)
  .then(() => console.log("MongoDB Connected: OEO Database"))
  .catch((err) => {
    console.error("DB FAILED:", err.message);
    process.exit(1);
  });

// Start Server
const PORT = Number(process.env.PORT) || 5000;
app.listen(PORT, () => {
  console.log(`OEO Backend LIVE on http://localhost:${PORT}`);
  console.log(`Test: http://localhost:${PORT}/`);
  console.log(`POS API: http://localhost:${PORT}/api/pos/products`);
});