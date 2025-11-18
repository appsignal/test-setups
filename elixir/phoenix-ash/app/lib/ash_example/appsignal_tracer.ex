defmodule AshExample.AppsignalTracer do
  @moduledoc """
  Custom Ash Tracer to add metadata (user_id, tenant, resource, action) to AppSignal spans.

  This tracer works alongside the existing ash_appsignal integration to provide
  contextual metadata for better observability in AppSignal. Extracts user_id from
  the actor context and attempts to extract tenant from various sources including
  process context fallbacks.

  Note: Ash tracers do not receive the tenant context that was passed to actions,
  so tenant extraction relies on the tenant being available in the process context
  or in record data when applicable.
  """
  @behaviour Ash.Tracer

  require Logger

  @impl Ash.Tracer
  def set_metadata(span_type, metadata) do
    # Only process action metadata for now
    if span_type == :action do
      # Extract metadata from the Ash action context (only actor, no DB queries)
      # Note: tenant extraction is not available because Ash tracers don't receive
      # the tenant context that was passed to actions
      tags =
        %{}
        |> add_tenant(metadata)
        |> add_user_id(metadata)
        |> add_resource_info(metadata)

      # Logger.debug("AppSignal metadata: #{inspect(tags)}")

      # Only set tags if we have meaningful data
      unless Enum.empty?(tags) do
        # Check if AppSignal is properly configured before setting data
        try do
          Appsignal.Span.set_sample_data(
            Appsignal.Tracer.root_span(),
            "tags",
            tags
          )
        rescue e ->
          Logger.debug("Failed to set AppSignal metadata: #{inspect(e)}")
        end
      end
    end

    :ok
  end

  @impl Ash.Tracer
  def start_span(_type, _name), do: :ok

  @impl Ash.Tracer
  def stop_span(), do: :ok

  @impl Ash.Tracer
  def get_span_context(), do: nil

  @impl Ash.Tracer
  def set_span_context(_context), do: :ok

  @impl Ash.Tracer
  def set_error(error) do
    try do
      Appsignal.Span.set_sample_data(
        Appsignal.Tracer.root_span(),
        "error",
        %{message: error.message, type: inspect(error.__struct__)}
      )
    rescue _ ->
      :ok
    end

    :ok
  end

  @impl Ash.Tracer
  def set_error(error, _opts) do
    set_error(error)
  end

  @impl Ash.Tracer
  def set_handled_error(error, _opts) do
    set_error(error)
  end

  # Tenant extraction - only from tenant context (no database queries)
  defp add_tenant(tags, metadata) do
    tenant = extract_tenant(metadata)
    if tenant, do: Map.put(tags, "tenant", tenant), else: tags
  end

  # User ID extraction - from actor context
  defp add_user_id(tags, metadata) do
    user_id = extract_user_id(metadata)
    if user_id, do: Map.put(tags, "user_id", user_id), else: tags
  end

  # Resource and action info for context
  defp add_resource_info(tags, metadata) do
    tags
    |> maybe_put_tag("resource", metadata[:resource])
    |> maybe_put_tag("action", metadata[:action])
  end

  # Helper function to conditionally add tags
  defp maybe_put_tag(map, _key, nil), do: map
  defp maybe_put_tag(map, key, value), do: Map.put(map, key, inspect(value))

  # Extract tenant from various sources (no database queries)
  # Based on debug logs, tenant is always nil in tracer metadata for this Ash application
  # The tenant context passed to Ash actions (e.g., tenant: tenant_id) is not included in tracer metadata
  # This is expected behavior - tracers receive metadata during execution but not the original context
  defp extract_tenant(%{changeset: %{tenant: tenant}}) when not is_nil(tenant), do: tenant
  # Handle the actual metadata structure that Ash provides to tracers
  # This matches the structure: %{domain: Domain, resource: Resource, action: :action, tenant: nil, actor: nil, ...}
  defp extract_tenant(%{tenant: tenant}) when not is_nil(tenant), do: tenant
  # Handle cases where tenant is nil - try to get from process context
  defp extract_tenant(%{tenant: nil}), do: extract_tenant_from_process_context()
  # Handle record data that might contain tenant
  defp extract_tenant(%{changeset: %{data: %{tenant: id}}}), do: id
  defp extract_tenant(%{record: %{tenant: id}}), do: id
  defp extract_tenant(%{record: record}), do: extract_tenant_from_record(record)
  # Fallback: try process context for any other metadata structure
  defp extract_tenant(_), do: extract_tenant_from_process_context()

  # Fallback: try to get tenant from process context (Ash might store it there)
  # This handles cases where tenant is nil in metadata but available in process context
  # Ash might store tenant in various process dictionary keys depending on the context
  defp extract_tenant_from_process_context() do
    # Try various process dictionary keys that Ash or the application might use for tenant
    Process.get(:tenant) ||
      Process.get(:ash_tenant) ||
      Process.get(:"$tenant") ||
      Process.get(:"$ash_tenant") ||
      nil
  end

  defp extract_tenant_from_record(%{tenant: id}), do: id
  defp extract_tenant_from_record(_), do: nil

  # Extract user_id from actor context (no database queries)
  defp extract_user_id(%{actor: actor}) when not is_nil(actor), do: actor.id
  defp extract_user_id(%{context: %{actor: actor}}) when not is_nil(actor), do: actor.id
  defp extract_user_id(_), do: nil
end
