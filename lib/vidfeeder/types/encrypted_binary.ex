defmodule VidFeeder.Types.EncryptedBinary do
  use Cloak.Fields.Binary, vault: VidFeeder.Vault
end
