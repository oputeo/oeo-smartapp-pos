import React from "react";
import { motion } from "framer-motion";
export const StatCard: React.FC<{ title: string; value: number; icon?: string }> = ({ title, value, icon }) => (
  <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} className="p-4 bg-white dark:bg-gray-800 rounded shadow flex items-center gap-4">
    <div className="text-3xl">{icon}</div>
    <div>
      <div className="text-sm text-gray-500">{title}</div>
      <div className="text-lg font-bold">{value.toLocaleString()}</div>
    </div>
  </motion.div>
);