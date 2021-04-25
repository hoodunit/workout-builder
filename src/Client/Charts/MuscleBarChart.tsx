import * as React from "react"
import { BarChart, Bar, XAxis, YAxis, Tooltip, ReferenceArea, ReferenceLine, ResponsiveContainer } from "recharts"
import { FC } from "react"

type MuscleChartProps = {
  muscles: Record<string, ChartMuscleExercises>
  barData: Record<string, Array<BarData>>
}

type BarData = {
  name: string
  targetCompound: number
  targetIsolation: number
  synergists: number
  stabilizers: number
}

type ChartMuscleExercises = {
  targetCompound: Array<string>
  targetIsolation: Array<string>
  synergists: Array<string>
  stabilizers: Array<string>
}

export const MuscleBarChart: FC<MuscleChartProps> = (props) => {
  const {muscles, barData} = props
  const groups = Object.keys(barData)
  const groupDivisions = groups.map((group: string, i: number) => {
    const line = i === 0 ? [] : [muscleGroupLine(barData[group][0].name)]
    return [...line, muscleGroupArea(barData[group], group)]
  })
  const data = Object.values(barData).flat()
  return (
    <ResponsiveContainer className="chart" width="100%" height="100%">
      <BarChart
        width={500}
        height={300}
        data={data}
        margin={{
          top: 20,
          right: 30,
          left: 20,
          bottom: 5,
        }}>
        <XAxis {...({angle: -90} as any)} dataKey="name" textAnchor="end" height={180} interval={0} />
        <YAxis {...{domain: [0, 50], label: {value: "Sets per week", angle: -90}, position: "insideLeft"}} />
        <Tooltip content={MuscleTooltip(muscles) as any} />
        {...groupDivisions.flat()}
        <ReferenceLine
          y={10}
          strokeDasharray="3 3"
          className="reference-line reference-line--strength"
        />
        <ReferenceLine
          y={15}
          strokeDasharray="3 3"
          className="reference-line reference-line--hypertrophy"
        />
        <ReferenceLine
          y={20}
          strokeDasharray="3 3"
          className="reference-line reference-line--strength"
        />
        <ReferenceLine
          y={30}
          strokeDasharray="3 3"
          className="reference-line reference-line--hypertrophy"
        />
        <ReferenceArea
          y1={15}
          y2={30}
          label={{value: "Hypertrophy range", position: "center", offset: 10}}
          className="reference reference-hypertrophy"
        />
        <ReferenceArea
          y1={10}
          y2={20}
          label={{value: "Strength range", position: "insideTop", offset: 10}}
          className="reference reference-strength"
        />
        <Bar dataKey="targetIsolation" stackId="primary" className="bar bar--isolation" maxBarSize={15}/>
        <Bar dataKey="targetCompound" stackId="primary" className="bar bar--compound" maxBarSize={15}/>
        <Bar dataKey="synergists" stackId="primary" className="bar bar--synergist" maxBarSize={15}/>
        <Bar dataKey="stabilizers" stackId="primary" className="bar bar--stabilizer" maxBarSize={8}/>
      </BarChart>
    </ResponsiveContainer>
  )
}

const round = (val: number): number => {
  return Math.round(val * 10) / 10
}

type TooltipProps = {
  active: boolean
  payload: any
  label: string
}

const MuscleTooltip = (muscles: Record<string, ChartMuscleExercises>) => ({ active, payload, label}: TooltipProps) => {
  if (!active || !payload || !payload.length) {
    return null
  }
  const {targetIsolation, targetCompound, synergists, stabilizers} = payload[0].payload
  const total = targetIsolation + targetCompound + synergists + stabilizers
  const exercises: ChartMuscleExercises | undefined = muscles[label]
  const exerciseCell = (exs: Array<string> | undefined) => {
    if(!exs) {
      return null
    }
    return exs.map((ex: string) => <div>{ex}</div>)
  }
  return (
    <div className="tooltip">
      <div className="tooltip__title">
        <table className="tooltip__table">
          <tbody>
          {targetIsolation > 0 && <tr className="tooltip__tr--isolation">
            <td className="tooltip__td--label">Targeted (isolation)</td>
            <td className="tooltip__td--text">{exerciseCell(exercises?.targetIsolation)}</td>
            <td className="tooltip__td--value">{`${round(targetIsolation)} sets`}</td>
          </tr>}
          { targetCompound > 0 && <tr className="tooltip__tr--compound">
            <td className="tooltip__td--label">Targeted (compound)</td>
            <td className="tooltip__td--text">{exerciseCell(exercises?.targetCompound)}</td>
            <td className="tooltip__td--value">{`${round(targetCompound)} sets`}</td>
          </tr>}
          {synergists > 0 && <tr className="tooltip__tr--synergist">
            <td className="tooltip__td--label">Supporting</td>
            <td className="tooltip__td--text">{exerciseCell(exercises?.synergists)}</td>
            <td className="tooltip__td--value">{`${round(synergists)} sets`}</td>
          </tr> }
          {stabilizers > 0 && <tr className="tooltip__tr--stabilizer">
            <td className="tooltip__td--label">Stabilizers</td>
            <td className="tooltip__td--text">{exerciseCell(exercises?.stabilizers)}</td>
            <td className="tooltip__td--value">{`${round(stabilizers)} sets`}</td>
          </tr> }
          {<tr>
            <td className="tooltip__td--label" />
            <td />
            <td className="tooltip__td--value">{`${round(total)} sets`}</td>
          </tr>}
          </tbody>
        </table>
      </div>
    </div>
  )
}

const muscleGroupArea = (group: Array<BarData>, name: string) => {
  return <ReferenceArea
    x1={group[0].name}
    x2={group[group.length - 1].name}
    ifOverflow="visible"
    label={{value: name, position: "insideTop", offset: 10}}
    className="reference-area--muscle-group"
  />
}

const muscleGroupLine = (x: string) => {
  return <ReferenceLine
    x={x}
    strokeDasharray="3 3"
    position="start"
    className="reference-line reference-line--bodypart"
  />
}
