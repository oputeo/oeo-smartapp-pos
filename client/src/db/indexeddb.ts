// src/db/indexeddb.ts
const DB_NAME = 'OEO_SmartApp_DB'
const DB_VERSION = 1
const STORES = ['transactions', 'customers', 'inventory', 'receipts', 'workflows']

let db: IDBDatabase | null = null

/**
 * Initialize or open the IndexedDB
 */
export const initDB = (): Promise<IDBDatabase> => {
  return new Promise((resolve, reject) => {
    if (db) {
      resolve(db)
      return
    }

    const request = indexedDB.open(DB_NAME, DB_VERSION)

    request.onerror = () => {
      console.error('IndexedDB: Failed to open database')
      reject(request.error)
    }

    request.onsuccess = () => {
      db = request.result
      console.log('IndexedDB: Database opened successfully')
      resolve(db)
    }

    request.onupgradeneeded = (event: any) => {
      const database = event.target.result

      STORES.forEach(storeName => {
        if (!database.objectStoreNames.contains(storeName)) {
          const store = database.createObjectStore(storeName, {
            keyPath: 'id',
            autoIncrement: true
          })

          // Optional: Add indexes
          if (storeName === 'transactions') {
            store.createIndex('date', 'date', { unique: false })
            store.createIndex('type', 'type', { unique: false })
          }
          if (storeName === 'customers') {
            store.createIndex('phone', 'phone', { unique: true })
            store.createIndex('name', 'name', { unique: false })
          }
        }
      })

      console.log('IndexedDB: Database upgraded to version', DB_VERSION)
    }
  })
}

/**
 * Save data to a store
 */
export const saveData = async <T>(storeName: string, data: T): Promise<number> => {
  const database = await initDB()
  return new Promise((resolve, reject) => {
    const transaction = database.transaction([storeName], 'readwrite')
    const store = transaction.objectStore(storeName)
    const request = store.add(data)

    request.onsuccess = () => {
      const id = request.result as number
      console.log(`IndexedDB: Saved to ${storeName} with ID`, id)
      resolve(id)
    }

    request.onerror = () => {
      console.error(`IndexedDB: Failed to save to ${storeName}`)
      reject(request.error)
    }

    transaction.oncomplete = () => {
      console.log(`IndexedDB: Transaction completed for ${storeName}`)
    }
  })
}

/**
 * Get all data from a store
 */
export const getAllData = async <T>(storeName: string): Promise<T[]> => {
  const database = await initDB()
  return new Promise((resolve, reject) => {
    const transaction = database.transaction([storeName], 'readonly')
    const store = transaction.objectStore(storeName)
    const request = store.getAll()

    request.onsuccess = () => {
      console.log(`IndexedDB: Retrieved ${request.result.length} items from ${storeName}`)
      resolve(request.result as T[])
    }

    request.onerror = () => {
      console.error(`IndexedDB: Failed to retrieve from ${storeName}`)
      reject(request.error)
    }
  })
}

/**
 * Get data by ID
 */
export const getDataById = async <T>(storeName: string, id: number): Promise<T | null> => {
  const database = await initDB()
  return new Promise((resolve, reject) => {
    const transaction = database.transaction([storeName], 'readonly')
    const store = transaction.objectStore(storeName)
    const request = store.get(id)

    request.onsuccess = () => {
      resolve(request.result as T ?? null)
    }

    request.onerror = () => reject(request.error)
  })
}

/**
 * Update existing data
 */
export const updateData = async <T>(storeName: string, data: T & { id: number }): Promise<void> => {
  const database = await initDB()
  return new Promise((resolve, reject) => {
    const transaction = database.transaction([storeName], 'readwrite')
    const store = transaction.objectStore(storeName)
    const request = store.put(data)

    request.onsuccess = () => {
      console.log(`IndexedDB: Updated ${storeName} ID`, data.id)
      resolve()
    }

    request.onerror = () => reject(request.error)
  })
}

/**
 * Delete data by ID
 */
export const deleteData = async (storeName: string, id: number): Promise<void> => {
  const database = await initDB()
  return new Promise((resolve, reject) => {
    const transaction = database.transaction([storeName], 'readwrite')
    const store = transaction.objectStore(storeName)
    const request = store.delete(id)

    request.onsuccess = () => {
      console.log(`IndexedDB: Deleted from ${storeName} ID`, id)
      resolve()
    }

    request.onerror = () => reject(request.error)
  })
}

/**
 * Clear entire store
 */
export const clearStore = async (storeName: string): Promise<void> => {
  const database = await initDB()
  return new Promise((resolve, reject) => {
    const transaction = database.transaction([storeName], 'readwrite')
    const store = transaction.objectStore(storeName)
    const request = store.clear()

    request.onsuccess = () => {
      console.log(`IndexedDB: Cleared store ${storeName}`)
      resolve()
    }

    request.onerror = () => reject(request.error)
  })
}

/**
 * Count items in store
 */
export const countItems = async (storeName: string): Promise<number> => {
  const database = await initDB()
  return new Promise((resolve, reject) => {
    const transaction = database.transaction([storeName], 'readonly')
    const store = transaction.objectStore(storeName)
    const request = store.count()

    request.onsuccess = () => resolve(request.result)
    request.onerror = () => reject(request.error)
  })
}