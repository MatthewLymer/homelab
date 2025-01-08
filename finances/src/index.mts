function delay(milliseconds: number) {
    return new Promise(resolve => setTimeout(resolve, milliseconds));
}

console.log("Awaiting...");

await delay(2000);

const recipient = "World";

console.log("Hello %s", recipient);

export {};