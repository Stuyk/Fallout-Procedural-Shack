Scriptname BaseDungeonScript extends ObjectReference
;===========================================
; DEFAULT OBJECT PROPERTIES
;===========================================
Static Property CeilingObject Auto
Static Property FoundationObject Auto
Static Property WallObject Auto
ObjectReference Property _attachedButton Auto
ObjectReference Property _startingPoint Auto
ObjectReference Property _objectSpawnSpot Auto
;===========================================
; TILE LISTS
;===========================================
FormList Property _floorTilesList Auto
FormList Property _wallTilesList Auto
FormList Property _ceilingTilesList Auto
;===========================================
; DEFAULT PROPERTIES
;===========================================
Actor Property PlayerREF Auto
;===========================================
; Variables
;===========================================
int _buttonState = 0
int _objectSpacing = 256 ; Space between default tile objects
int _objectYSpacing = 196 ; Space between wall stacks.
;===========================================
; Grid Properties
;===========================================
int _gridX = 5
int _gridY = 5
;===========================================
; Called when the button is activated.
;===========================================
Event OnActivate(ObjectReference akActionRef)
    ; If the player is activating it, go to button states.
    ; Generate the dungeon.
    If (_buttonState == 0)
        GenerateDungeon()
    ; Clear the dungeon;
    ElseIf (_buttonState == 1)
        ClearDungeon()
    ; Pause before doing anything else.
    ElseIf (_buttonState == 2)
        Debug.Notification("Please wait while the area is generated.")
    EndIf
EndEvent
;===========================================
; Begins Dungeon Generation
;===========================================
Function GenerateDungeon()
    _buttonState = 2
    ; =========
    ; FLOORS
    ; =========
    GenerateFloorTiles(_startingPoint.GetPositionX(), _startingPoint.GetPositionY(), _startingPoint.GetPositionZ(), _floorTilesList)
    GenerateWallTiles(_startingPoint.GetPositionX(), _startingPoint.GetPositionY(), _startingPoint.GetPositionZ(), _wallTilesList)
    GenerateCeilingTiles(_startingPoint.GetPositionX(), _startingPoint.GetPositionY(), _startingPoint.GetPositionZ(), _ceilingTilesList)
    ; Set Button State to 1 so that we know the next option is to clear the dungeon.
    _buttonState = 1
    Debug.Notification("Complete Size: " + _floorTilesList.GetSize())
EndFunction
;===========================================
; Reload Object
;===========================================
Function ReloadObject(ObjectReference object)
    object.Disable()
    object.Enable()
EndFunction
;===========================================
; Generate Floor Tiles
;===========================================
Function GenerateFloorTiles(Float xStartPoint, Float yStartPoint, Float zStartPoint, FormList targetList)
    int yCount = 0
    While (yCount < _gridY)
        int xCount = 0
        While (xCount < _gridX)
            ObjectReference object = _objectSpawnSpot.PlaceAtMe(FoundationObject)
            targetList.AddForm(object)
            object.SetPosition(xStartPoint + (_objectSpacing * xCount), yStartPoint + (_objectSpacing * yCount), zStartPoint)
            ReloadObject(object)
            xCount += 1
        EndWhile
        yCount += 1
    EndWhile
EndFunction
;===========================================
; Generate Ceiling Tiles
;===========================================
Function GenerateCeilingTiles(Float xStartPoint, Float yStartPoint, Float zStartPoint, FormList targetList)
    int yCount = 0
    While (yCount < _gridY)
        int xCount = 0
        While (xCount < _gridX)
            ObjectReference object = _objectSpawnSpot.PlaceAtMe(CeilingObject)
            targetList.AddForm(object)
            object.SetPosition(xStartPoint + (_objectSpacing * xCount), yStartPoint + (_objectSpacing * yCount), zStartPoint + (_objectYSpacing * 2))
            ReloadObject(object)
            xCount += 1
        EndWhile
        yCount += 1
    EndWhile
EndFunction
;===========================================
; Generate Outter Wall Tiles
;===========================================
Function GenerateWallTiles(Float xStartPoint, Float yStartPoint, Float zStartPoint, FormList targetList)
    int yCount = 0
    While (yCount < _gridY)
        int xCount = 0
        While (xCount < _gridX)
            ; Generate Bottom Walls
            If (yCount == 0 && xCount >= 1)
                ObjectReference object = _objectSpawnSpot.PlaceAtMe(WallObject)
                object.SetPosition(xStartPoint + (_objectSpacing * xCount), yStartPoint + (_objectSpacing * yCount), zStartPoint)
                RotateCorner(object, targetList, 0) ; Bottom
                ; Second stack
                object = _objectSpawnSpot.PlaceAtMe(WallObject)
                object.SetPosition(xStartPoint + (_objectSpacing * xCount), yStartPoint + (_objectSpacing * yCount), zStartPoint + _objectYSpacing)
                RotateCorner(object, targetList, 0) ; Bottom
            EndIf
            ; Generate Top Walls
            If (yCount == _gridY - 1)
                ObjectReference object = _objectSpawnSpot.PlaceAtMe(WallObject)
                object.SetPosition(xStartPoint + (_objectSpacing * xCount), yStartPoint + (_objectSpacing * yCount), zStartPoint)
                RotateCorner(object, targetList, 180) ; Top
                ; Second Stack
                object = _objectSpawnSpot.PlaceAtMe(WallObject)
                object.SetPosition(xStartPoint + (_objectSpacing * xCount), yStartPoint + (_objectSpacing * yCount), zStartPoint + _objectYSpacing)
                RotateCorner(object, targetList, 180) ; Top
            EndIf
            ; Generate Left Walls
            If (xCount == 0)
                ObjectReference object = _objectSpawnSpot.PlaceAtMe(WallObject)
                object.SetPosition(xStartPoint + (_objectSpacing * xCount), yStartPoint + (_objectSpacing * yCount), zStartPoint)
                RotateCorner(object, targetList, 90) ; Left
                ; Second Stack
                object = _objectSpawnSpot.PlaceAtMe(WallObject)
                object.SetPosition(xStartPoint + (_objectSpacing * xCount), yStartPoint + (_objectSpacing * yCount), zStartPoint + _objectYSpacing)
                RotateCorner(object, targetList, 90) ; Left
            EndIf
            ; Generate Right Walls
            If (xCount == _gridX - 1)
                ObjectReference object = _objectSpawnSpot.PlaceAtMe(WallObject)
                object.SetPosition(xStartPoint + (_objectSpacing * xCount), yStartPoint + (_objectSpacing * yCount), zStartPoint)
                RotateCorner(object, targetList, 270) ; Right
                ; Second Stack
                object = _objectSpawnSpot.PlaceAtMe(WallObject)
                object.SetPosition(xStartPoint + (_objectSpacing * xCount), yStartPoint + (_objectSpacing * yCount), zStartPoint + _objectYSpacing)
                RotateCorner(object, targetList, 270) ; Left
            EndIf
            xCount += 1
        EndWhile
        yCount += 1
    EndWhile
EndFunction
; Generate Corner
Function RotateCorner(ObjectReference object, FormList listReference, Float zRot)
    listReference.AddForm(object)
    RotateToPosition(object, zRot)
EndFunction
; Just rotates an object on the zAxis
Function RotateToPosition(ObjectReference object, Float zRot)
    object.SetAngle(object.GetAngleX(), object.GetAngleY(), (object.GetAngleZ() + zRot))
    ReloadObject(object)
EndFunction
;===========================================
; Called when the button state is at 1.
;===========================================
Function ClearDungeon()
    Debug.Notification("Starting Grid Reset")
    _buttonState = 2
    ; ============================
    ; Cleanup Tiles
    ; ============================
    CleanupTilePieces(_floorTilesList)
    CleanupTilePieces(_ceilingTilesList)
    CleanupTilePieces(_wallTilesList)
    ; ===
    ; END
    ; ===
    _buttonState = 0
    Debug.Notification("Reset Size: " + _floorTilesList.GetSize())
EndFunction
;===========================================
; Called by ClearDungeon(), cleans up any FormList data.
;===========================================
Function CleanupTilePieces(FormList currentList)
    Int iIndex = currentList.GetSize()
    While (iIndex)
        iIndex -= 1
        ObjectReference object = currentList.GetAt(iIndex) As ObjectReference
        object.Delete()
        object.Disable()
        currentList.RemoveAddedForm(currentList.GetAt(iIndex))
    EndWhile
EndFunction

