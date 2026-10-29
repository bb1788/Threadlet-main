// Standalone Mill/Verilator adapter. Not part of the Chipyard/FireSim sources.
// FireSim uses the real annotation implementation from its own targetutils.
package midas.targetutils
object SynthesizePrintf {
  def apply[T](statement: T): T = statement
}
