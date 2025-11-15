import { useState } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { POS } from './components/POS';
import './App.css';

const queryClient = new QueryClient();

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <div className="min-h-screen bg-gray-50">
        <POS />
      </div>
    </QueryClientProvider>
  );
}

export default App;