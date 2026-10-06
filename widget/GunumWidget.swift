import WidgetKit
import SwiftUI

// !!! Kendi adresinle değiştir: GitHub Pages üzerindeki hadis.json
let hadisURL = URL(string: "https://KULLANICI_ADIN.github.io/gunum/hadis.json")!

struct Hadis: Codable { let metin: String; let kaynak: String; let cikarim: String }
struct Entry: TimelineEntry { let date: Date; let hadis: Hadis }

let yedek = Hadis(metin: "Ameller niyetlere göredir.", kaynak: "Buhârî, Bed'ü'l-vahy 1; Müslim, İmâret 155", cikarim: "")

func gunIndeksi(_ d: Date, _ n: Int) -> Int {
    // Web uygulamasıyla aynı formül: UTC gün sayısı % hadis sayısı
    Int(d.timeIntervalSince1970 / 86400) % max(n, 1)
}

struct Provider: TimelineProvider {
    func placeholder(in c: Context) -> Entry { Entry(date: Date(), hadis: yedek) }
    func getSnapshot(in c: Context, completion: @escaping (Entry) -> Void) { completion(placeholder(in: c)) }
    func getTimeline(in c: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let ud = UserDefaults.standard
        let bitis = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400 + 60)
        URLSession.shared.dataTask(with: hadisURL) { data, _, _ in
            if let data = data { ud.set(data, forKey: "hadis") }
            let veri = data ?? ud.data(forKey: "hadis")
            let liste = veri.flatMap { try? JSONDecoder().decode([Hadis].self, from: $0) } ?? []
            let h = liste.isEmpty ? yedek : liste[gunIndeksi(Date(), liste.count)]
            completion(Timeline(entries: [Entry(date: Date(), hadis: h)], policy: .after(bitis)))
        }.resume()
    }
}

struct GunumView: View {
    @Environment(\.widgetFamily) var fam
    let e: Entry
    var body: some View {
        switch fam {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text("Günün Hadisi").font(.caption2).bold()
                Text(e.hadis.metin).font(.caption).lineLimit(3)
            }
        default:
            VStack(alignment: .leading, spacing: 6) {
                Text("Günün Hadisi").font(.caption).foregroundColor(.yellow)
                Text("“\(e.hadis.metin)”").font(.system(.body, design: .serif))
                Text(e.hadis.kaynak).font(.caption2).foregroundColor(.secondary)
            }.padding()
        }
    }
}

@main struct GunumWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "GunumWidget", provider: Provider()) { e in
            if #available(iOS 17.0, *) { GunumView(e: e).containerBackground(.black, for: .widget) } else { GunumView(e: e) }
        }
        .configurationDisplayName("Günün Hadisi")
        .description("Günün hadisini gösterir.")
        .supportedFamilies([.accessoryRectangular, .systemMedium, .systemSmall])
    }
}
