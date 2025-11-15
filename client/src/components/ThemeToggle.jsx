import React, { useEffect, useState } from "react";

export default function ThemeToggle() {
  const [dark, setDark] = useState(false);

  useEffect(() => {
    try {
      const saved = localStorage.getItem("theme");
      if (saved === "dark") {
        document.documentElement.classList.add("dark");
        setDark(true);
      } else {
        document.documentElement.classList.remove("dark");
        setDark(false);
      }
    } catch (e) {
      // ignore
    }
  }, []);

  function toggle() {
    try {
      const willDark = !dark;
      setDark(willDark);
      if (willDark) {
        document.documentElement.classList.add("dark");
        localStorage.setItem("theme", "dark");
      } else {
        document.documentElement.classList.remove("dark");
        localStorage.setItem("theme", "light");
      }
    } catch (e) {
      // ignore
    }
  }

  return (
    <button
      onClick={toggle}
      aria-label="Toggle theme"
      className="px-3 py-1 rounded border hover:shadow-sm"
    >
      {dark ? "Switch to Light" : "Switch to Dark"}
    </button>
  );
}
