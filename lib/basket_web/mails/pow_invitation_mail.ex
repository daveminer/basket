defmodule BasketWeb.PowInvitationMail do
  @moduledoc false

  use BasketWeb, :mail

  def invitation(assigns) do
    %Pow.Phoenix.Mailer.Template{
      subject: "You've been invited",
      html: ~H"""
      <h3>Hi,</h3>
      <p>
        You've been invited by <strong><%= @invited_by_user_id %></strong>. Please use the following link to accept your invitation:
      </p>
      <p><a href="{@url}">{@url}</a></p>
      """,
      text: ~P"""
      Hi,

      You've been invited by <%= @invited_by_user_id %>. Please use the following link to accept your invitation:

      {@url}
      """
    }
  end
end
