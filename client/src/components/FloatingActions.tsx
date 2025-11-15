import { motion } from "framer-motion";

export const FloatingActions = () => (
  <motion.div initial={{opacity:0,y:50}} animate={{opacity:1,y:0}} className="fixed bottom-8 right-8 flex flex-col gap-2">
    {["New Customer","New Invoice","New Purchase","New Expense"].map(a=><button key={a} className="btn btn-primary btn-sm">{a}</button>)}
  </motion.div>
);
