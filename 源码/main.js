const { app, BrowserWindow, ipcMain, screen } = require("electron");
const path = require("path");

app.disableHardwareAcceleration();

let petWindow = null;
let pendingTaskComplete = false;

const hasTaskCompleteFlag = process.argv.includes("--task-complete");
const lock = app.requestSingleInstanceLock();

if (!lock) {
  app.quit();
} else {
  app.on("second-instance", (_event, argv) => {
    if (argv.includes("--task-complete")) {
      sendTaskComplete();
    }

    if (petWindow) {
      petWindow.show();
      petWindow.focus();
    }
  });

  app.whenReady().then(() => {
    createPetWindow();

    if (hasTaskCompleteFlag) {
      pendingTaskComplete = true;
    }
  });

  app.on("window-all-closed", () => {
    app.quit();
  });
}

function createPetWindow() {
  petWindow = new BrowserWindow({
    width: 230,
    height: 240,
    x: getInitialX(),
    y: getInitialY(),
    frame: false,
    transparent: true,
    backgroundColor: "#00000000",
    alwaysOnTop: true,
    skipTaskbar: true,
    resizable: false,
    hasShadow: false,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true,
      nodeIntegration: false,
      backgroundThrottling: false,
    },
  });

  petWindow.setBackgroundColor("#00000000");
  petWindow.setAlwaysOnTop(true, "screen-saver");
  petWindow.loadFile(path.join(__dirname, "index.html"));

  petWindow.webContents.once("did-finish-load", () => {
    if (pendingTaskComplete) {
      pendingTaskComplete = false;
      sendTaskComplete();
    }
  });
}

function getInitialX() {
  const { workArea } = screen.getPrimaryDisplay();
  return workArea.x + workArea.width - 260;
}

function getInitialY() {
  const { workArea } = screen.getPrimaryDisplay();
  return workArea.y + workArea.height - 300;
}

function sendTaskComplete() {
  if (!petWindow || petWindow.isDestroyed()) {
    pendingTaskComplete = true;
    return;
  }

  petWindow.webContents.send("pet:task-complete");
}

ipcMain.handle("pet-window:move-to", (_event, point) => {
  if (!petWindow || petWindow.isDestroyed()) return;

  const [width, height] = petWindow.getContentSize();
  const nextX = Number.isFinite(point?.x) ? Math.round(point.x) : 0;
  const nextY = Number.isFinite(point?.y) ? Math.round(point.y) : 0;
  const petBounds = getPetBoundsInWindow(point?.petBounds, width, height);
  const display = screen.getDisplayNearestPoint({
    x: Math.round(nextX + petBounds.left + petBounds.width / 2),
    y: Math.round(nextY + petBounds.top + petBounds.height / 2),
  });
  const { bounds } = display;

  const x = clampToRange(nextX, bounds.x - petBounds.left, bounds.x + bounds.width - petBounds.right);
  const y = clampToRange(nextY, bounds.y - petBounds.top, bounds.y + bounds.height - petBounds.bottom);

  petWindow.setPosition(x, y, false);
});

ipcMain.handle("pet-window:resize", (_event, size) => {
  if (!petWindow || petWindow.isDestroyed()) return;

  const width = clamp(Math.round(size?.width ?? 230), 120, 520);
  const height = clamp(Math.round(size?.height ?? 240), 120, 560);

  petWindow.setContentSize(width, height, false);
});

ipcMain.handle("pet-window:close", () => {
  if (!petWindow || petWindow.isDestroyed()) return;

  petWindow.close();
});

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

function clampToRange(value, min, max) {
  if (min > max) {
    return Math.round((min + max) / 2);
  }

  return clamp(value, min, max);
}

function getPetBoundsInWindow(bounds, windowWidth, windowHeight) {
  const left = Number.isFinite(bounds?.left) ? Math.round(bounds.left) : 0;
  const top = Number.isFinite(bounds?.top) ? Math.round(bounds.top) : 0;
  const width = Number.isFinite(bounds?.width) ? Math.round(bounds.width) : windowWidth;
  const height = Number.isFinite(bounds?.height) ? Math.round(bounds.height) : windowHeight;
  const normalizedWidth = clamp(width, 1, windowWidth);
  const normalizedHeight = clamp(height, 1, windowHeight);
  const normalizedLeft = clamp(left, 0, windowWidth - normalizedWidth);
  const normalizedTop = clamp(top, 0, windowHeight - normalizedHeight);

  return {
    left: normalizedLeft,
    top: normalizedTop,
    right: normalizedLeft + normalizedWidth,
    bottom: normalizedTop + normalizedHeight,
    width: normalizedWidth,
    height: normalizedHeight,
  };
}
