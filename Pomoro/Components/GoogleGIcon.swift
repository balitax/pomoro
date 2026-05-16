//
//  GoogleGIcon.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//


import SwiftUI

struct GoogleGIcon: View {
    var body: some View {
        Canvas { ctx, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = min(size.width, size.height) / 2

            var arc = Path()
            arc.addArc(center: center, radius: r,
                       startAngle: .degrees(135), endAngle: .degrees(225), clockwise: false)
            arc.addArc(center: center, radius: r * 0.55,
                       startAngle: .degrees(225), endAngle: .degrees(135), clockwise: true)
            ctx.fill(arc, with: .color(Color(red: 0.26, green: 0.52, blue: 0.96)))

            var top = Path()
            top.addArc(center: center, radius: r,
                       startAngle: .degrees(225), endAngle: .degrees(330), clockwise: false)
            top.addArc(center: center, radius: r * 0.55,
                       startAngle: .degrees(330), endAngle: .degrees(225), clockwise: true)
            ctx.fill(top, with: .color(Color(red: 0.92, green: 0.26, blue: 0.21)))

            var bot = Path()
            bot.addArc(center: center, radius: r,
                       startAngle: .degrees(330), endAngle: .degrees(405), clockwise: false)
            bot.addArc(center: center, radius: r * 0.55,
                       startAngle: .degrees(405), endAngle: .degrees(330), clockwise: true)
            ctx.fill(bot, with: .color(Color(red: 0.98, green: 0.74, blue: 0.02)))

            var green = Path()
            green.addArc(center: center, radius: r,
                         startAngle: .degrees(45), endAngle: .degrees(135), clockwise: false)
            green.addArc(center: center, radius: r * 0.55,
                         startAngle: .degrees(135), endAngle: .degrees(45), clockwise: true)
            ctx.fill(green, with: .color(Color(red: 0.20, green: 0.66, blue: 0.33)))

            ctx.fill(Path(ellipseIn: CGRect(x: center.x - r * 0.55,
                                            y: center.y - r * 0.55,
                                            width: r * 1.1, height: r * 1.1)),
                     with: .color(.white))

            let barH = r * 0.28
            let barY = center.y - barH / 2
            ctx.fill(Path(CGRect(x: center.x, y: barY, width: r * 0.9, height: barH)),
                     with: .color(Color(red: 0.26, green: 0.52, blue: 0.96)))
        }
    }
}
