defmodule BasketWeb.Components.CardTest do
  use BasketWeb.ConnCase, async: true
  use Surface.LiveViewTest

  catalogue_test BasketWeb.Card
end
