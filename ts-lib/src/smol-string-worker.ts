const worker = new Worker(new URL("./worker.ts", import.meta.url), {
	type: "module",
});

let nextID = 0;
const resolver: Record<number, (str: string) => void> = {};

worker.onmessage = function (e: { data: { id: number; data: string } }) {
	const id = e.data.id;
	resolver[id](e.data.data);
	delete resolver[id];
};

export async function compress(data: string) {
	const id = nextID++;
	return new Promise<string>((resolve) => {
		resolver[id] = resolve;
		worker.postMessage({ command: "compress", id, data });
	});
}

export async function decompress(data: string) {
	const id = nextID++;
	return new Promise<string>((resolve) => {
		resolver[id] = resolve;
		worker.postMessage({ command: "decompress", id, data });
	});
}
