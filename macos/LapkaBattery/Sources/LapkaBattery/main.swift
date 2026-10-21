import AppKit

final class BatteryApp: NSObject, NSApplicationDelegate {
    private let device = HIDBatteryDevice()
    private var statusItem: NSStatusItem!
    private var leftItem: NSMenuItem!
    private var rightItem: NSMenuItem!
    private var swapItem: NSMenuItem!
    private var bootloaderItem: NSMenuItem!
    private var timer: Timer?
    private var swapped = UserDefaults.standard.bool(forKey: "swapHalves")
    private var bootloaderConfirmation = BootloaderConfirmation()
    private var bootloaderResetWork: DispatchWorkItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let menu = NSMenu()
        leftItem = NSMenuItem(title: "Левая: —", action: nil, keyEquivalent: "")
        rightItem = NSMenuItem(title: "Правая: —", action: nil, keyEquivalent: "")
        menu.addItem(leftItem)
        menu.addItem(rightItem)
        menu.addItem(.separator())
        swapItem = NSMenuItem(title: "Поменять половинки местами", action: #selector(toggleSwap), keyEquivalent: "")
        swapItem.target = self
        swapItem.state = swapped ? .on : .off
        menu.addItem(swapItem)
        let refreshItem = NSMenuItem(title: "Обновить", action: #selector(refresh), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)
        menu.addItem(.separator())
        bootloaderItem = NSMenuItem(title: "Режим прошивки донгла…", action: #selector(bootloaderClicked), keyEquivalent: "")
        bootloaderItem.target = self
        menu.addItem(bootloaderItem)
        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Выход", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        statusItem.menu = menu

        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    @objc private func toggleSwap() {
        swapped.toggle()
        UserDefaults.standard.set(swapped, forKey: "swapHalves")
        swapItem.state = swapped ? .on : .off
        refresh()
    }

    @objc private func refresh() {
        guard let report = device.read() else {
            statusItem.button?.title = "Л — · П —"
            leftItem.title = "Левая: —"
            rightItem.title = "Правая: —"
            return
        }
        let left = swapped ? report.slot1 : report.slot0
        let right = swapped ? report.slot0 : report.slot1
        func display(_ value: Int?) -> String { value.map { "\($0)%" } ?? "нет данных" }
        statusItem.button?.title = report.menuBarTitle(swapped: swapped)
        leftItem.title = "Левая: \(display(left))"
        rightItem.title = "Правая: \(display(right))"
    }

    @objc private func bootloaderClicked() {
        if !bootloaderConfirmation.click(at: Date.timeIntervalSinceReferenceDate) {
            bootloaderItem.title = "Подтвердить: режим прошивки донгла"
            bootloaderResetWork?.cancel()
            let reset = DispatchWorkItem { [weak self] in
                self?.bootloaderConfirmation.cancel()
                self?.bootloaderItem.title = "Режим прошивки донгла…"
            }
            bootloaderResetWork = reset
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: reset)
            return
        }
        bootloaderResetWork?.cancel()
        bootloaderResetWork = nil
        bootloaderItem.title = "Режим прошивки донгла…"
        if device.enterBootloader() {
            statusItem.button?.title = "Донгл: загрузчик"
        } else {
            bootloaderItem.title = "Донгл не найден — повторить"
        }
    }

    @objc private func quit() { NSApplication.shared.terminate(nil) }
}

let app = NSApplication.shared
let delegate = BatteryApp()
app.delegate = delegate
app.run()
