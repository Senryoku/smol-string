// @ts-expect-error
import Worker from "./worker.js?worker&inline";

const worker = new Worker();

let nextID = 0;
const resolver: Record<number, (str: string) => void> = {};

worker.onmessage = function (e: { data: { id: number; data: string } }) {
	console.log("onmessage", e);
	const id = e.data.id;
	resolver[id](e.data.data);
	delete resolver[id];
};

export async function compress(data: string) {
	const id = nextID++;
	console.log("compress", id);
	return new Promise((resolve) => {
		resolver[id] = resolve;
		worker.postMessage({ command: "compress", id, data });
	});
}

export async function decompress(data: string) {
	const id = nextID++;
	console.log("decompress", id);
	return new Promise((resolve) => {
		resolver[id] = resolve;
		worker.postMessage({ command: "decompress", id, data });
	});
}
