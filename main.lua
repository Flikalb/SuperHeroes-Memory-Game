-----------------------------------------------------------------------------------------
--
-- SuperHeroes Memory Game / Author: Lucie Boutou
--
-----------------------------------------------------------------------------------------

-- Hide Status Bar
display.setStatusBar(display.HiddenStatusBar)

-- Require external libraries
local widget = require( "widget" )
local json = require("json")

-- Background
local sky = display.newImage( "bg_clouds.jpg" )
sky.x = 160; sky.y = 240

-- Title View
local titleText
local playButton
local scoreButton
local colsText
local colsValue
local rowsText
local rowsValue
local colsUpButton
local rowsUpButton
local colsDownsButton
local rowsDownButton
local darkBackground
local msgText
local titleView

-- Resume View
local blackBackground
local scoreText
local restartButton
local backButton
local resumeView

-- Game View
local cards={}
local cardsBack = {}
local timeText
local gameView

-- Score View
local scoreTitleText
local scoreScrollArea
local scoreBackButton
local scoreView

-- Variables
local width = 64
local flippedCount
local flippedIndexes = {}
local remainingPairs
local pairFlippedEvent
local eventRunning
local cardsNumber

-- Function
local Main = {}

local showTitleView = {}
local showGameView = {}
local showResumeView = {}
local showScoreView = {}

local hideTitleView = {}
local hideGameView = {}
local hideResumeView = {}
local hideScoreView = {}

local upButtonRelease = {}
local downButtonRelease = {}
local playButtonRelease = {}
local scoreButtonRelease = {}
local backgroundListener = {}

local restartButtonRelease = {}
local backButtonRelease = {}

local hideScoreRelease = {}

local cardHandler = {}
local pairFlippedListener = {}
local switchBackCardsListener = {}
local timerListener = {}

local shuffle = {}
local fileExists = {}
local saveScore = {}
local readScore = {}

-- Main Function
function Main()
    showTitleView()
end

-- ShowTitleView Function
function showTitleView()

    if titleView == nil then
        
        titleView = display.newGroup()
        
        titleText = display.newText("SuperHeroes Memory",0,0,native.systemFont,30)
        titleText.x = 160; titleText.y = 70
        titleView:insert(titleText)
        
        rowsValue = 2
        rowsText = display.newText("Rows:  "..rowsValue,0,0,native.systemFont,20)
        rowsText.anchorX = 0; rowsText.x = 90; rowsText.y = 165;
        titleView:insert(rowsText)
        
        colsValue = 2
        colsText = display.newText("Cols:  "..colsValue,0,0,native.systemFont,20)
        colsText.anchorX = 0; colsText.x = 90; colsText.y = 235;
        titleView:insert(colsText)
        
        rowsUpButton = widget.newButton
        {
            id="rows",
            defaultFile = "buttonArrow.png",
            overFile = "buttonArrowOver.png",
            emboss = true,
            onRelease = upButtonRelease,
        }
        rowsUpButton.x = 200; rowsUpButton.y = 150
        rowsUpButton:rotate(-90)
        titleView:insert(rowsUpButton)
        
        rowsDownButton = widget.newButton
        {
            id="rows",
            defaultFile = "buttonArrow.png",
            overFile = "buttonArrowOver.png",
            emboss = true,
            onRelease = downButtonRelease,
        }
        rowsDownButton.x = 200; rowsDownButton.y = 180
        rowsDownButton:rotate(90)
        titleView:insert(rowsDownButton)
        
        colsUpButton = widget.newButton
        {
            id="cols",
            defaultFile = "buttonArrow.png",
            overFile = "buttonArrowOver.png",
            emboss = true,
            onRelease = upButtonRelease,
        }
        colsUpButton.x = 200; colsUpButton.y = 220
        colsUpButton:rotate(-90)
        titleView:insert(colsUpButton)
        
        colsDownButton = widget.newButton
        {
            id="cols",
            defaultFile = "buttonArrow.png",
            overFile = "buttonArrowOver.png",
            emboss = true,
            onRelease = downButtonRelease,
        }
        colsDownButton.x = 200; colsDownButton.y = 250
        colsDownButton:rotate(90)
        titleView:insert(colsDownButton)
        
        playButton = widget.newButton
        {
            defaultFile = "buttonWhite.png",
            overFile = "buttonWhiteOver.png",
            label = "PLAY",
            emboss = true,
            onRelease = playButtonRelease,
        }
        playButton.x = 160; playButton.y = 320
        titleView:insert(playButton)
        
        scoreButton = widget.newButton
        {
            defaultFile = "buttonWhite.png",
            overFile = "buttonWhiteOver.png",
            label = "SCORES",
            emboss = true,
            onRelease = scoreButtonRelease,
        }
        scoreButton.x = 160; scoreButton.y = 400
        titleView:insert(scoreButton)
        
    else
        titleView.isVisible = true
    end

end

-- HideTitleView Function
function hideTitleView()

    if titleView ~= nil then
        titleView.isVisible = false
    end
end

-- ShowGameView Function
function showGameView()
    gameView = display.newGroup()

    -- init game
    cards = {}
    cardsBack = {}
    flippedIndexes = {}
    flippedCount = 0
    gameView:addEventListener("pairFlipped",pairFlippedListener)
    cardsNumber = rowsValue*colsValue
    remainingPairs = cardsNumber/2
    timeText = display.newText( "0", display.contentCenterX, 380, native.systemFontBold, 80 )
    timeText.anchorY = 0
    timeText:setFillColor( 0, 0, 0 )
    timer.performWithDelay( 1000, timerListener, 50 )
    gameView:insert(timeText)

    -- setting pairs
    local val = 1
    for i = 1, cardsNumber do
        if(val > cardsNumber/2) then
            val = 1
        end
        cards[i]= {value = val}
        val = val + 1
    end
    shuffle(cards)

    -- drawing cards
    local scaleRatio
    if width*rowsValue>380 and width*colsValue>300 then
        scaleRatio = math.min((380/(width*rowsValue)),(300/(width*colsValue)))
    elseif width*rowsValue>380 then
        scaleRatio = 380/(width*rowsValue)
    elseif width*colsValue>300 then
        scaleRatio = 300/(width*colsValue)
    else
        scaleRatio = nil
    end
    
    if scaleRatio ~= nil then
        width = width*scaleRatio
    end
    
    for i = 1, rowsValue do
        for j=1, colsValue do
            index= (i-1)*colsValue + j
            local cardButton = widget.newButton
            {
                id=index,
                defaultFile = "card.png",
                emboss=true,
                onPress = cardHandler
            }
            
            local xValue = display.contentCenterX - (colsValue*width/2)-width/2+j*width
            local yValue = 200 - (rowsValue*width/2)-width/2+i*width
            
            cardButton.x = xValue; cardButton.y = yValue
            cardsBack[index] = cardButton
            
            cards[index].card = display.newImage("img"..cards[index].value..".png",xValue,yValue)
            cards[index].card.isVisible = false
            
            if scaleRatio ~= nil then
                cardButton:scale(scaleRatio,scaleRatio)
                cards[index].card:scale(scaleRatio,scaleRatio)
            end
            
            gameView:insert(cardButton)
            gameView:insert(cards[index].card)
            
        end
     end
end

-- HideGameView Function()
function hideGameView()
    display.remove(gameView)
    gameView = nil
end

-- ShowResumeView Function
function showResumeView()
    
    if resumeView == nil then
        blackBackground = display.newRect(160,240,320,480)
        blackBackground:setFillColor(0,0.7)
        
        scoreText = display.newText("Score: "..timeText.text,display.contentCenterX,100,native.systemFont)
        
        restartButton = widget.newButton
        {
            defaultFile = "buttonWhite.png",
            overFile = "buttonWhiteOver.png",
            label = "RESTART",
            emboss = true,
            onRelease = restartButtonRelease,
        }
        restartButton.x = 160; restartButton.y = 200
        
        backButton = widget.newButton
        {
            defaultFile = "buttonWhite.png",
            overFile = "buttonWhiteOver.png",
            label = "BACK",
            emboss = true,
            onRelease = backButtonRelease
        }
        backButton.x = 160; backButton.y = 280
        
        resumeView = display.newGroup()
        resumeView:insert(blackBackground)
        resumeView:insert(scoreText)
        resumeView:insert(restartButton)
        resumeView:insert(backButton)
     else
        scoreText.text = "Score: "..timeText.text
        resumeView.isVisible = true
     end
     
     saveScore(cardsNumber,timeText.text)

end

-- HideResumeView Function
function hideResumeView()
    if resumeView ~= nil then
        resumeView.isVisible = false
    end
end

-- ShowScoreView Function
function showScoreView()

    if scoreView == nil then
        scoreView = display.newGroup()
        
        scoreTitleText = display.newText("Scores",0,0,native.systemFont,30)
        scoreTitleText.x = 160; scoreTitleText.y = 40
        scoreView:insert(scoreTitleText)

        scoreBackButton = widget.newButton
        {
            defaultFile = "buttonArrow.png",
            overFile = "buttonArrowOver.png",
            emboss = true,
            onRelease = hideScoreRelease
        }
        scoreBackButton:rotate(180)
        scoreBackButton.x = 160; scoreBackButton.y = 450;
        scoreView:insert(scoreBackButton)
        
    else
        scoreView.isVisible = true;
    end
    
    scores = readScore()    
    list = {}
    for key,value in pairs(scores) do
            list[#list+1] = tonumber(key)
    end
    table.sort(list)
    
    scoreScrollArea = widget.newScrollView
    {
        x=160,
        y=250,
        width=300,
        height=350,
        backgroundColor={1.0,1.0,1.0,0.3},
        bottomPadding = 50
    }
    local tempText = display.newText("Grid size",80,20,native.systemFontBold,20)
    tempText.anchorY = 0
    scoreScrollArea:insert(tempText)
    tempText = display.newText("Best score",220,20,native.systemFontBold,20)
    tempText.anchorY = 0
    scoreScrollArea:insert(tempText)
    
    local height = 40
    for k=1,#list do
        height = height + 40;
        tempText = display.newText(list[k],80,height,native.systemFont,16)
        tempText:setFillColor(0.0)
        scoreScrollArea:insert(tempText)
        tempText = display.newText(scores[tostring(list[k])],220,height,native.systemFont,16)
        tempText:setFillColor(0.0)
        scoreScrollArea:insert(tempText)
    end
    scoreView:insert(scoreScrollArea)

end

-- HideScoreView()
function hideScoreView()
    scoreView.isVisible = false
    display.remove(scoreScrollArea)
    scoreScrollArea = nil
end

-- UpButtonRelease Function
function upButtonRelease(event)
    if event.target.id == "rows" then
        rowsValue = rowsValue + 1
        rowsText.text = "Rows:  "..rowsValue
    else
        colsValue = colsValue + 1
        colsText.text = "Cols:  "..colsValue
    end
end

-- DownButtonRelease Function
function downButtonRelease(event)
    if event.target.id == "rows" and rowsValue>1 then
        rowsValue = rowsValue - 1
        rowsText.text = "Rows:  "..rowsValue
    elseif event.target.id == "cols" and colsValue>1 then
        colsValue = colsValue - 1
        colsText.text = "Cols:  "..colsValue
    end
end

-- PlayButtonRelease Function
function playButtonRelease(event)
    local msg
    if rowsValue*colsValue > 20 then
        msg = "Maximum of 20 squares for the grid, please update rows and cols values to match this."
    elseif (rowsValue*colsValue)%2 ~= 0 then
        msg = "The number of squares must be even, please update rows or cols values to match this."
    end
    
    if msg == nil then
        hideTitleView()
        showGameView()
    else
        darkBackground = display.newRect(160,240,320,480)
        darkBackground:setFillColor(0,0.95)
        darkBackground:addEventListener("touch",backgroundListener)
        msgText = display.newText(msg,160,100,200,0,native.systemFont,"center")
        playButton:setEnabled(false)
    end
    
end

-- ScoreButtonRelease Function
function scoreButtonRelease(event)
    hideTitleView()
    showScoreView()
end

-- BackgroundListener Function
function backgroundListener(event)
    display.remove(darkBackground)
    display.remove(msgText)
    darkBackground = nil
    msgText = nil
    playButton:setEnabled(true)
end

-- RestartButton
function restartButtonRelease(event)
    hideResumeView()
    hideGameView()
    showGameView()
end

-- BackButtonRelease Function
function backButtonRelease(event)
    hideGameView()
    hideResumeView()
    showTitleView()
end

-- HideScoreRelease Function
function hideScoreRelease(event)
    hideScoreView()
    showTitleView()
end

-- CardHandler Function
function cardHandler(event)
    if flippedCount<2 then
        if  not cards[event.target.id].card.isVisible then
            cards[event.target.id].card.isVisible = true
            flippedCount = flippedCount + 1
            flippedIndexes[flippedCount] = event.target.id
        end
    end
    if flippedCount == 2 and not eventRunning then
        eventRunning = true
        pairFlippedEvent = {
            name = "pairFlipped"
        }
        gameView:dispatchEvent(pairFlippedEvent)
    end
end

-- PairFlippedListener Function
function pairFlippedListener(event)
    if(cards[flippedIndexes[1]].value == cards[flippedIndexes[2]].value) then
        cardsBack[flippedIndexes[1]].isVisible = false
        cardsBack[flippedIndexes[2]].isVisible = false
        remainingPairs = remainingPairs - 1
        if remainingPairs == 0 then
            hideGameView()
            showResumeView()
        end    
        flippedIndexes = {}
        flippedCount = 0
        eventRunning = false
    else
        timer.performWithDelay(1000,switchBackCardsListener)
    end
    
end

-- SwitchBackCardsListener Function
function switchBackCardsListener(event)
    cards[flippedIndexes[1]].card.isVisible = false
    cards[flippedIndexes[2]].card.isVisible = false
    flippedIndexes = {}
    flippedCount = 0
    eventRunning = false
end

-- TimerListener Function
function timerListener(event)
    if remainingPairs == 0 then
		timer.pause(event.source)
	else
        local count = event.count
        timeText.text = count
    end
end

-- Shuffle Function
function shuffle(t)
    local rand = math.random 
    local iterations = #t
    local j
    
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

-- FileExists Function
function fileExists(fileName, base)
  assert(fileName, "fileName is missing")
  local base = base or system.DocumentsDirectory
  local filePath = system.pathForFile( fileName, base)
  local exists = false
 
  if (filePath) then -- file may exist. won't know until you open it
    local fileHandle = io.open( filePath, "r" )
    if (fileHandle) then -- nil if no file found
      exists = true
      io.close(fileHandle)
    end
  end
 
  return(exists)
end

-- SaveScore Function
function saveScore(size,score)

    local path = system.pathForFile("scores.txt",system.DocumentsDirectory)
    local scoreFile = nil
    local scoresString = ""
    local scores = {}
    
    if fileExists("scores.txt",system.DocumentsDirectory) then
        scoreFile = io.open(path,"r+")
        scoresString = scoreFile:read("*a")
        scores = json.decode(scoresString)
        if scores[tostring(size)] == nil or tonumber(score)<tonumber(scores[tostring(size)]) then
            scores[tostring(size)] = score
            scoresString = json.encode(scores)
            scoreFile:seek("set")
            scoreFile:write(scoresString)
        end
    else
        scoreFile = io.open(path,"w")
        scores[tostring(size)] = score
        scoresString = json.encode(scores)
        scoreFile:write(scoresString)
    end
    
    io.close(scoreFile)
    scoreFile = nil
end

-- ReadScore Function
function readScore()

    local path = system.pathForFile("scores.txt",system.DocumentsDirectory)
    local scoreFile = nil
    local scoresString = ""
    local scores = {}
    
    if fileExists("scores.txt",system.DocumentsDirectory) then
        scoreFile = io.open(path,"r")
        scoresString = scoreFile:read("*a")
        scores = json.decode(scoresString)
        io.close(scoreFile)
        scoreFile = nil
        return scores
    end
    return nil
end

Main()