import React from "react";
import { motion } from "framer-motion";
interface Props { title:string; value:number; icon:string }
export const StatCard:React.FC<Props>=({title,value,icon})=>(
  <motion.div initial={{opacity:0,y:20}} animate={{opacity:1,y:0}} transition={{duration:0.5}} className="p-4 bg-white dark:bg-gray-800 rounded-lg shadow flex items-center gap-4">
    <div className="text-3xl">{icon}</div>
    <div><div className="text-gray-500 dark:text-gray-400">{title}</div><div className="text-xl font-bold">{value.toLocaleString()}</div></div>
  </motion.div>
);
