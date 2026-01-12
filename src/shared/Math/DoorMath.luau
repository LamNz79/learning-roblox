local DoorMath = {}

-- Define the type
export type DoorMathType = {
	computePivotToHinge: (CFrame, CFrame) -> CFrame,
	getHingeCFrame: (CFrame, CFrame, number) -> CFrame,
}

function DoorMath.computePivotToHinge(modelPivot: CFrame, hingeCFrame: CFrame): CFrame
	return modelPivot:Inverse() * hingeCFrame
end

function DoorMath.getHingeCFrame(hingeCFrame: CFrame, pivotToHinge: CFrame, degrees: number): CFrame
	return hingeCFrame * CFrame.Angles(0, math.rad(degrees), 0) * pivotToHinge:Inverse()
end

return DoorMath
