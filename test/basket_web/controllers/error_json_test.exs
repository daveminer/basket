defmodule BasketWeb.ErrorJSONTest do
  @moduledoc false
  use BasketWeb.ConnCase, async: true

  test "renders 404" do
    assert BasketWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert BasketWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
