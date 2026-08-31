defmodule Live.Home.Component.Terminal do

  use Phoenix.Component
  import Demo.CoreComponents

  def terminal(assigns) do
    ~H"""
    <div
      phx-hook=".JigsawTerminal"
      phx-update="ignore"
      class="w-full h-full overflow-wrap font-mono min-h-0 text-sm bg-slate-900 rounded-sm" id="terminal_component">
      <!-- Terminal header -->
        <div class="flex h-7 shrink-0 items-center border-b border-white/10 px-2">
          <div class="ml-3 w-full flex items-center justify-between gap-1 text-sm text-gray-400">
            <div>
              <.icon name="hero-command-line" class="size-5" />
              <span>{"Terminal"}</span>
            </div>
            <button phx-click="close" class="hover:cursor-pointer text-normal" phx-value-pane="terminal"> x </button>
          </div>
        </div>

        <div id="terminal-output" class="min-h-0 flex-1 overflow-y-auto p-3 ">

          <div class="text-white">
            <pre>
              ___  ___  ________  ________  ________  ___       __
            |\  \|\  \|\   ____\|\   ____\|\   __  \|\  \     |\  \
            \ \  \ \  \ \  \___|\ \  \___|\ \  \|\  \ \  \    \ \  \
          __ \ \  \ \  \ \  \  __\ \_____  \ \   __  \ \  \  __\ \  \
          |\  \\_\  \ \  \ \  \|\  \|____|\  \ \  \ \  \ \  \|\__\_\  \
          \ \________\ \__\ \_______\____\_\  \ \__\ \__\ \____________\
          \|________|\|__|\|_______|\_________\|__|\|__|\|____________|
                                    \|_________|

            </pre>
          </div>
            <div class="text-gray-500">
              Type <span class="text-green-400">help</span> for available commands.
            </div>

            <div class="mt-2 flex">
              <span class="mr-2 text-green-400">></span>

              <input
                id="terminal-input"
                type="text"
                class="min-w-0 flex-1 border-0 bg-transparent p-0 text-gray-200 outline-none focus:ring-0"
                autocomplete="off"
                spellcheck="false"
                autofocus
              />
            </div>
          </div>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".JigsawTerminal">
      export default {
        mounted() {
          this.input = document.getElementById("terminal-input")
          this.output = document.getElementById("terminal-output")

          this.commands = {
            help: () => [
              "-------- Available commands --------",
              "\n",
              "  help\t:\tShow available commands",
              "  about\t:\tAbout Jigsaw",
              "\n"
            ],

            about: () => [
              "-------- Jigsaw --------",
              "\n",
              "Jigsaw is a proof of concept for a display tiling library.",
              "\n",
              "Right now, we can create and split panes. Click on any of the icons below and it will open a new pane.",
              "\n",
              "The layout is currently generated with a variant the binary space partitioning algorithm",
              "\n",
              "Built with Elixir and Phoenix LiveView."
            ]
          }

          this.handleKeydown = (event) => {
            if (event.key !== "Enter") return

            const command = this.input.value.trim().toLowerCase()

            if (!command) return

            this.write(`$ ${command}`, "text-gray-300")

            this.input.value = ""

            if (this.commands[command]) {
              this.commands[command]().forEach(line => {
                this.write(line, "text-gray-400")
              })
            } else {
              this.write(
                `Command not found: ${command}`,
                "text-red-400"
              )

              this.write(
                "Type 'help' for available commands.",
                "text-gray-500"
              )
            }

            this.output.scrollTop = this.output.scrollHeight
          }

          this.input.addEventListener("keydown", this.handleKeydown)

          this.input.focus()
        },

        destroyed() {
          this.input?.removeEventListener(
            "keydown",
            this.handleKeydown
          )
        },

        write(text, className = "") {
          const line = document.createElement("div")

          line.className = className

          if (text === "\n") {
            line.textContent = "\u00A0"
          } else {
            line.textContent = text
          }

          this.output.insertBefore(
            line,
            this.input.parentElement
          )

          this.output.scrollTop = this.output.scrollHeight
        }
      }
    </script>
    """
  end
end
