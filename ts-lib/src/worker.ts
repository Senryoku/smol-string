import { compress, decompress } from "./smol-string.js";

export type Message = {
	command: string;
	id: number;
	data: string;
};

onmessage = async function (e: { data: Message }) {
	const { command, id, data } = e.data;
	switch (command) {
		case "decompress": {
			postMessage({ id, data: decompress(data) });
			break;
		}
		case "compress": {
			postMessage({ id, data: compress(data) });
			break;
		}
	}
};
