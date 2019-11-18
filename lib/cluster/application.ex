defmodule Cluster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    topologies = [
      k8s_cluster: [
        strategy: Cluster.Strategy.Kubernetes.DNS,
        config: [
          service: "cluster-nodes",
          application_name: "cluster"
        ]
      ]
    ]

    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      {Cluster.Supervisor, [topologies, [name: Cluster.ClusterSupervisor]]},
      ClusterWeb.Endpoint
      # Starts a worker by calling: Cluster.Worker.start_link(arg)
      # {Cluster.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cluster.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ClusterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
