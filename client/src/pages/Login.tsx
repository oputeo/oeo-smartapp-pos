import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import useAuthStore from "../stores/useAuthStore";

export default function Login() {
  const navigate = useNavigate();
  const login = useAuthStore((s) => s.login);
  const [user, setUser] = useState("");
  const handle = async (e?: React.FormEvent) => {
    e?.preventDefault();
    login({ name: user, token: "demo-token" });
    navigate("/");
  };
  return (
    <form onSubmit={handle} className="w-full max-w-md bg-white dark:bg-gray-900 p-6 rounded shadow">
      <h2 className="text-xl font-semibold mb-4">Sign in</h2>
      <input value={user} onChange={(e) => setUser(e.target.value)} className="input input-bordered w-full mb-3" placeholder="username" />
      <div className="flex justify-end">
        <button type="submit" className="btn btn-primary">Sign in</button>
      </div>
    </form>
  );
}