export interface Dict { [key: string]: string }

export interface UpdateHandlerInterface {
    (name: string, value: string[]): void
}

export interface FilterTarget {
    name: string,
    level: string
}

export interface StartHandlerInterface {
    (filters: FilterTarget[]): void
}

export interface StopHandlerIterface {
    (): void
}