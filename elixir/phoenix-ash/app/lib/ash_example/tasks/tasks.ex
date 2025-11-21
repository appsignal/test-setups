defmodule AshExample.Tasks do
  use Ash.Domain

  resources do
    resource AshExample.Tasks.Task
  end
end
