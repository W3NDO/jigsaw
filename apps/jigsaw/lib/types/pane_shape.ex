defmodule Types.PaneShape do
  @moduledoc """
  Defines the shape of a pane based on it's parent Node.
  """

  alias Types.ValidationError

  @type point :: {number(), number()}

  @type t :: %__MODULE__{position: point(), width: number(), height: number()}

  defstruct [:position, :width, :height]

  @spec validate_points(__MODULE__.t()) :: {:ok, :valid} | {:error, :shape_invariant_breach}
  def validate_points(%__MODULE__{position: {point_x, point_y}, width: width, height: height}) do
    all_greater_than_zero = Enum.all?([point_x, point_y, width, height], &greater_than_zero(&1))

    case all_greater_than_zero do
      true ->
        {:ok, :valid}

      false ->
        {:error,
         %ValidationError{
           subject: :shape,
           id: nil,
           validation: :pane_shape,
           reason: :points_less_than_zero,
           message: "Points are less than zero"
         }}
    end
  end

  def validate_points(nil),
    do:
      {:error,
       %ValidationError{
         subject: :shape,
         id: nil,
         validation: :pane_shape,
         reason: :unkown,
         message: "Points are nil"
       }}

  defp greater_than_zero(num) when is_number(num) and num >= 0, do: true
  defp greater_than_zero(num) when is_number(num), do: false
end
