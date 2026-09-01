defmodule Live.Home.Component.Music do
  @moduledoc """
  Rickroll component
  """
  use Phoenix.Component
  import Demo.CoreComponents

  def music(assigns) do
    ~H"""
    <div id="music-pane" class="w-full h-full bg-slate-900 rounded-sm" phx-update="ignore">
      <div class="flex h-7 shrink-0 items-center border-b border-white/10 px-2">
        <div class="ml-3 w-full flex items-center justify-between gap-1 text-sm text-gray-400">
          <div>
            <.icon name="hero-play" class="size-5" />
            <span>{"Music"}</span>
          </div>
          <button phx-click="close" class="hover:cursor-pointer text-normal" phx-value-pane="music">
            x
          </button>
        </div>
      </div>
      <iframe
        class="min-h-[95%] h-[95%] w-full"
        src="https://www.youtube.com/embed/dQw4w9WgXcQ?si=Cjn3RZ-dZzJnQZ2m?autoplay=1&mute=1"
        title="get rickrolled lol :)"
        frameborder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
        referrerpolicy="strict-origin-when-cross-origin"
        allowfullscreen
      >
      </iframe>
    </div>
    """
  end
end
