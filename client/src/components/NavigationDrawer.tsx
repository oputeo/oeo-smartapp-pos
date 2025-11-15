import { useState } from "react";
import { motion } from "framer-motion";

export const NavigationDrawer = () => {
  const [open, setOpen] = useState(true);
  const items = ["Home","Sales","Purchases","Inventory","Reports"];
  return (
    <motion.div initial={{x:-300}} animate={{x:open?0:-300}} className="fixed top-0 left-0 h-full w-64 bg-white dark:bg-gray-800 shadow-lg p-4 z-50">
      <button className="btn btn-sm mb-4" onClick={()=>setOpen(!open)}>{open ? "Close" : "Open"}</button>
      <ul>{items.map(i=><li key={i} className="my-2 hover:text-blue-500">{i}</li>)}</ul>
    </motion.div>
  );
};
