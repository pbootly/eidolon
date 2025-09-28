# eidolon
A simple database comparison engine

## Configuration
```toml
[source.db1]
host = "127.0.0.1"
port = 3306
username = "root"
password = "rootpass"

[target.db2]
source = "source.db1"
host = "127.0.0.1"
port = 3307
username = "root"
password = "rootpass"

```

## Invokation
```sh
elixir eidolon.exs your_config.toml 
```

## Try it out with Docker Compose

```sh
docker compose up -d
```

Then run the comparison:

```sh
elixir eidolon.exs compose-test.toml
```
