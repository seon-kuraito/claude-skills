fr 是 fractional unit，grid 專用的長度單位。

grid-template-columns: 1fr 1fr 1fr 就是三等分。

重點是 fr 分配的是剩餘空間，不是總寬度。所以 grid-template-columns: 200px 1fr 的時候，1fr 拿到的是扣掉 200px 之後剩下的那塊。

跟 auto 的差別：auto 會先看內容決定寬度，fr 是直接吃剩餘空間。

常見的坑：以為 1fr 1fr 一定等寬，但只要其中一格內容很長就不等寬。原因是 grid item 的 min-width 預設是 auto，內容會把格子撐開。要避免就寫 minmax(0, 1fr)。

gap 也是先扣掉才分配剩餘空間。
