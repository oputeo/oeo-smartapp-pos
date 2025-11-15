import { create } from 'zustand'

export type User = { name: string; token: string } | null

interface AuthState {
  user: User
  login: (u: User) => void
  logout: () => void
}

const useAuthStore = create<AuthState>((set) => ({
  user: null,
  login: (u) => set({ user: u }),
  logout: () => set({ user: null }),
}))

export default useAuthStore