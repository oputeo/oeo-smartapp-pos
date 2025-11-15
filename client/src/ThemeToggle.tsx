import { useEffect, useState } from "react";

export default function ThemeToggle() {
  const [dark, setDark] = useState(false);
  useEffect(() => { if(dark) document.documentElement.classList.add("dark"); else document.documentElement.classList.remove("dark"); },[dark]);
  return <button className="btn btn-sm btn-primary" onClick={()=>setDark(!dark)}>{dark?"Light":"Dark"} Mode</button>;
}
