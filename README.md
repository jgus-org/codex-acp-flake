# codex-acp

A Nix flake that provides [codex-acp](https://github.com/agentclientprotocol/codex-acp), a stdio [Agent Client Protocol](https://agentclientprotocol.com/) agent server that drives the OpenAI Codex CLI from an ACP client.

## Outputs

`packages.<system>.codex-acp`, also `packages.<system>.default`, on `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, and `aarch64-darwin`: `bin/codex-acp`, which speaks ACP over stdin/stdout. Configure it as the agent command of an ACP client.

```sh
nix run .#codex-acp
```

## Notes

- The package carries the Codex CLI it launches, built for the same platform, so you do not need to install anything alongside it. `CODEX_PATH` points the adapter at a different Codex binary.
- Codex authentication comes from the environment the server runs in: a ChatGPT sign-in, an API key, or a gateway the client supplies.
- Session modes list the permission profiles the current config allows. A turn sends the selected profile's ID instead of the sandbox policy the ACP session declares. The adapter reads the session's starting profile from `config/read`, which reports config layers only. A profile mandated by managed `requirements.toml` alone is not selected for a new session, so state `default_permissions` in a config layer such as `/etc/codex/config.toml`. The built-in read-only and full-access modes keep the declared sandbox policy.

See [LICENSE.md](LICENSE.md) for licensing and copyright, and [NOTICE.md](NOTICE.md) for the terms of upstream and distributed artifacts.
