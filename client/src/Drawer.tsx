import { Link } from "react-router-dom";
export default function Drawer() {
  return (
    <div className="w-64 bg-gray-100 dark:bg-gray-800 h-screen p-4 space-y-4">
      <Link className="block p-2 rounded hover:bg-gray-200 dark:hover:bg-gray-700" to="/">Home</Link>
      <Link className="block p-2 rounded hover:bg-gray-200 dark:hover:bg-gray-700" to="/sales">Sales</Link>
      <Link className="block p-2 rounded hover:bg-gray-200 dark:hover:bg-gray-700" to="/purchases">Purchases</Link>
      <Link className="block p-2 rounded hover:bg-gray-200 dark:hover:bg-gray-700" to="/reports">Reports</Link>
    </div>
  );
}
