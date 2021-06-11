import * as React from "react"
import * as ReactDOM from "react-dom"
import { MuscleBarChart } from "root/Client/Charts/MuscleBarChart"

export const render = (elemId: string) => (props: any) => (val: any) => {
  const elem = document.getElementById(elemId)
  if (!elem) {
    setTimeout(() => {
      render(elemId)(props)(val)
    }, 0)
    return val
  }
  try {
    ReactDOM.render(<MuscleBarChart {...props} />, elem)
  } catch (e) {
    console.error('Bar chart rendering failed', e)
    return val
  }
  return val
}
