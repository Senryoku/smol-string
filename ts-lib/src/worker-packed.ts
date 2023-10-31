import { compressPacked, decompressPacked } from "./smol-string-packed.js";

export type Message = {
	command: string;
	id: number;
	data: string;
};

onmessage = async function (e: { data: Message }) {
	const { command, id, data } = e.data;
	switch (command) {
		case "decompress": {
			postMessage({ id, data: decompressPacked(data) });
			break;
		}
		case "compress": {
			postMessage({ id, data: compressPacked(data) });
			break;
		}
	}
};
