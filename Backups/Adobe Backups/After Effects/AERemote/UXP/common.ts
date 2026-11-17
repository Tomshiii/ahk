/**
 * @fileoverview Common After Effects actions (exposed as `ae/common/...`), the counterpart of `actions/common.ts` for Premiere Pro.
 */

import { AE_ACTION_PREFIX } from "premiereremote-shared/config";
import { registry } from "../../generated/registry";

/**
 * returns all After Effects functions as a json string
 * @param {boolean} [pretty] whether to indent the json
 * @returns {string}
 */
export async function getRegistryJSON(pretty = false): Promise<string> {
    const serializable = Object.fromEntries(
        Object.entries(registry)
            .filter(([name]) => name.startsWith(AE_ACTION_PREFIX))
            .map(([name, entry]) => [name, { params: entry.params }]),
    );
    return JSON.stringify(serializable, null, pretty ? 2 : 0);
}

/**
 * Reloads the panel so a freshly built bundle/registry is picked up.
 * @param {number} [delayMs] delay before reloading, so the response can be sent back first
 * @returns {string}
 */
export async function reloadPanel(delayMs = 200): Promise<string> {
    setTimeout(() => location.reload(), delayMs);
    return "reloading";
}