defmodule Types.ValidationError do
  @moduledoc """
  This represents a validation error of a Node, Tree or a Pane.
  """

  defexception [
    :subject,
    :id,
    :validation,
    :reason,
    message: "default message"
  ]

  @type subject :: :layout | :pane | :node | :shape
  @type reason ::
          :unkown
          | :position_less_than_zero
          | :ratio_invariant
          | :direction_invariant
          | :ratio_and_direction_invariant
          | :invalid_pane_shape
  @type validation :: :node | :pane | :pane_shape

  @type t :: %__MODULE__{
          subject: subject(),
          id: String.t() | nil,
          validation: validation(),
          reason: reason()
        }
end
