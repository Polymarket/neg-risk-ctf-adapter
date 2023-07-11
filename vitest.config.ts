import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    globalSetup: ["ts/test/setup/globalSetup.ts"],
  },
});
