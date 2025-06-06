defmodule BasketWeb.Components.ArticleSummary do
  @moduledoc """
  Provides a summary of a news article as an element in the news index.
  """

  import BasketWeb.CoreComponents

  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div class="card shadow-xl bg-base-200">
      <div class="card-body">
        <div class="flex text-sm justify-end w-auto">
          <%= @news.updated_date |> Calendar.strftime("%B %d, %Y %I:%M %p") %>
        </div>
        <h2 class="card-title my-4">
          <div>
            <.link href={@news.url}>
              <%= @news.headline %>
            </.link>
          </div>
        </h2>
        <p><%= @news.summary %></p>

        <div id={"article-content-#{@news.id}"} class="hidden article-summary">
          <%= HtmlSanitizeEx.basic_html(@news.content) |> Phoenix.HTML.raw() %>
        </div>

        <div id={"article-toggle-open-#{@news.id}"} class="flex card-actions justify-end">
          <.icon
            name="hero-chevron-down"
            class="article-content-toggle h-5 w-5 opacity-40 hover:opacity-70"
          />
        </div>

        <div id={"article-toggle-close-#{@news.id}"} class="flex card-actions justify-end hidden">
          <.icon
            name="hero-chevron-up"
            class="article-content-toggle h-5 w-5 opacity-40 hover:opacity-70"
          />
        </div>
      </div>
    </div>
    """
  end
end
