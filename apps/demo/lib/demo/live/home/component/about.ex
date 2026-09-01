defmodule Live.Home.Component.About do
  @moduledoc """
  About component
  """
  use Phoenix.Component
  import Demo.CoreComponents

  def about(assigns) do
    ~H"""
    <div class="w-full h-full bg-slate-900 rounded-sm flex flex-col">
      <div class="flex h-7 shrink-0 items-center border-b border-white/10 px-2">
        <div class="ml-3 w-full flex items-center justify-between gap-1 text-sm text-gray-400">
          <div>
            <.icon name="hero-information-circle" class="size-5" />
            <span>{"About"}</span>
          </div>
          <button phx-click="close" class="hover:cursor-pointer text-normal" phx-value-pane="about">
            x
          </button>
        </div>
      </div>
      <div class="text-white w-full flex flex-col items-center justify-around flex-1 overflow-y-auto">
        <div class="m-auto min-w-[70%] w-[70%] overflow-y-auto min-h-[20%] h-[80%]">
          <h1 class="text-2xl py-2">What is Jigsaw</h1>
          <p>
            Jigsaw is a proof of concept for a layout tiling library to be used with phoenix Liveview.
          </p>

          <h1 class="text-2xl py-2">What it can do</h1>
          <p class="font-justify">
            Right now, we can create and split panes. Click on any of the icons below and it will open a new pane.
          </p>

          <p>
            Currently using the <strong> Binary Space Partitioning </strong>
            algorithm to build the layout.
          </p>

          <h1 class="text-2xl py-2">The plan</h1>
          <ul>
            <li>Make it a fully fledged Phoenix library for dashboards.</li>
            <li>Manage state of the panes. Right now when you close a pane, it loses it's state.</li>
            <li>
              Implement the frontend API with
              <a href="https://hologram.page" target="_blank">
                <span class="font-bold underline"> Hologram </span>
              </a>
            </li>
          </ul>
        </div>
      </div>
    </div>
    """
  end
end
