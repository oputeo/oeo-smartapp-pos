import React from "react";
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from "recharts";
import { motion } from "framer-motion";
interface Props{reportType:string;period:string}
const data=[{name:"Mon",value:400},{name:"Tue",value:300},{name:"Wed",value:500},{name:"Thu",value:200},{name:"Fri",value:278},{name:"Sat",value:189},{name:"Sun",value:239}];
export const LineChartWidget:React.FC<Props>=({reportType,period})=>(
  <motion.div initial={{opacity:0,y:20}} animate={{opacity:1,y:0}} className="p-4 bg-white dark:bg-gray-800 rounded-lg shadow">
    <h3 className="text-lg font-semibold mb-2">{reportType} ({period})</h3>
    <ResponsiveContainer width="100%" height={250}><LineChart data={data}><CartesianGrid strokeDasharray="3 3"/><XAxis dataKey="name" stroke="#8884d8"/><YAxis stroke="#8884d8"/><Tooltip/><Line type="monotone" dataKey="value" stroke="#3B82F6" strokeWidth={2}/></LineChart></ResponsiveContainer>
  </motion.div>
);
