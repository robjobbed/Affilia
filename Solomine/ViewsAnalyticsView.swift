//
//  AnalyticsView.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeriod: AnalyticsPeriod = .month
    @State private var selectedMetric: AnalyticsMetric = .earnings
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack(spacing: Theme.Spacing.xs) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                Text("BACK")
                                    .font(Theme.Typography.caption)
                            }
                            .foregroundColor(Theme.Colors.accent)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, Theme.Spacing.sm)
                    
                    // Title
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("ANALYTICS")
                            .font(Theme.Typography.headingLarge)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Track your performance and growth")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    // Period selector
                    periodSelector
                        .padding(.horizontal, Theme.Spacing.md)
                    
                    // Key metrics overview
                    keyMetricsSection
                    
                    // Chart section
                    chartSection
                    
                    // Detailed stats
                    detailedStatsSection
                    
                    // Top performing gigs
                    topGigsSection
                    
                    Spacer(minLength: Theme.Spacing.xl)
                }
                .padding(.bottom, Theme.Spacing.md)
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Period Selector
    
    private var periodSelector: some View {
        HStack(spacing: Theme.Spacing.xs) {
            ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                Button(action: { selectedPeriod = period }) {
                    Text(period.rawValue)
                        .font(Theme.Typography.caption)
                        .foregroundColor(selectedPeriod == period ? Theme.Colors.background : Theme.Colors.accent)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, Theme.Spacing.xs)
                        .background(selectedPeriod == period ? Theme.Colors.accent : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                .stroke(Theme.Colors.accent, lineWidth: 1)
                        )
                        .cornerRadius(Theme.CornerRadius.small)
                }
            }
        }
    }
    
    // MARK: - Key Metrics
    
    private var keyMetricsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("KEY METRICS")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .padding(.horizontal, Theme.Spacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.sm) {
                    AnalyticsMetricCard(
                        title: "TOTAL EARNINGS",
                        value: "$23,750",
                        change: "+12.5%",
                        isPositive: true,
                        icon: "dollarsign.circle.fill"
                    )
                    
                    AnalyticsMetricCard(
                        title: "COMPLETED PROJECTS",
                        value: "8",
                        change: "+3",
                        isPositive: true,
                        icon: "checkmark.circle.fill"
                    )
                    
                    AnalyticsMetricCard(
                        title: "PROFILE VIEWS",
                        value: "342",
                        change: "+45%",
                        isPositive: true,
                        icon: "eye.fill"
                    )
                    
                    AnalyticsMetricCard(
                        title: "AVG. RATING",
                        value: "4.9",
                        change: "+0.1",
                        isPositive: true,
                        icon: "star.fill"
                    )
                }
                .padding(.horizontal, Theme.Spacing.md)
            }
        }
    }
    
    // MARK: - Chart Section
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("PERFORMANCE TRENDS")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .padding(.horizontal, Theme.Spacing.md)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                // Metric selector
                HStack(spacing: Theme.Spacing.xs) {
                    ForEach(AnalyticsMetric.allCases, id: \.self) { metric in
                        Button(action: { selectedMetric = metric }) {
                            Text(metric.rawValue)
                                .font(Theme.Typography.tiny)
                                .foregroundColor(selectedMetric == metric ? Theme.Colors.background : Theme.Colors.textSecondary)
                                .padding(.horizontal, Theme.Spacing.xs)
                                .padding(.vertical, 4)
                                .background(selectedMetric == metric ? Theme.Colors.accent : Theme.Colors.surface)
                                .cornerRadius(Theme.CornerRadius.small)
                        }
                    }
                }
                
                // Chart
                EarningsChart(period: selectedPeriod, metric: selectedMetric)
                    .frame(height: 200)
            }
            .padding(Theme.Spacing.md)
            .terminalCard()
            .padding(.horizontal, Theme.Spacing.md)
        }
    }
    
    // MARK: - Detailed Stats
    
    private var detailedStatsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("DETAILED STATISTICS")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .padding(.horizontal, Theme.Spacing.md)
            
            VStack(spacing: Theme.Spacing.sm) {
                StatRow(label: "ACTIVE GIGS", value: "3", icon: "briefcase.fill")
                StatRow(label: "TOTAL CLIENTS", value: "24", icon: "person.2.fill")
                StatRow(label: "REPEAT CLIENTS", value: "8", icon: "arrow.clockwise")
                StatRow(label: "AVG. PROJECT VALUE", value: "$2,968", icon: "chart.bar.fill")
                StatRow(label: "RESPONSE TIME", value: "< 2 hrs", icon: "clock.fill")
                StatRow(label: "COMPLETION RATE", value: "100%", icon: "checkmark.seal.fill")
            }
            .padding(.horizontal, Theme.Spacing.md)
        }
    }
    
    // MARK: - Top Gigs
    
    private var topGigsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("TOP PERFORMING GIGS")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .padding(.horizontal, Theme.Spacing.md)
            
            VStack(spacing: Theme.Spacing.sm) {
                TopGigRow(
                    rank: 1,
                    title: "Custom iOS Dashboard",
                    earnings: "$12,500",
                    orders: 4
                )
                
                TopGigRow(
                    rank: 2,
                    title: "SwiftUI Consulting",
                    earnings: "$8,750",
                    orders: 7
                )
                
                TopGigRow(
                    rank: 3,
                    title: "API Integration",
                    earnings: "$2,500",
                    orders: 5
                )
            }
            .padding(.horizontal, Theme.Spacing.md)
        }
    }
}

// MARK: - Supporting Views

struct AnalyticsMetricCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.Colors.accent)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 10, weight: .bold))
                    Text(change)
                        .font(Theme.Typography.tiny)
                }
                .foregroundColor(isPositive ? .green : .red)
            }
            
            Text(value)
                .font(Theme.Typography.headingLarge)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text(title)
                .font(Theme.Typography.tiny)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.md)
        .frame(width: 160)
        .terminalCard()
    }
}

struct EarningsChart: View {
    let period: AnalyticsPeriod
    let metric: AnalyticsMetric
    
    var sampleData: [ChartDataPoint] {
        switch period {
        case .week:
            return [
                ChartDataPoint(label: "Mon", value: 850),
                ChartDataPoint(label: "Tue", value: 1200),
                ChartDataPoint(label: "Wed", value: 950),
                ChartDataPoint(label: "Thu", value: 1800),
                ChartDataPoint(label: "Fri", value: 2100),
                ChartDataPoint(label: "Sat", value: 600),
                ChartDataPoint(label: "Sun", value: 400)
            ]
        case .month:
            return [
                ChartDataPoint(label: "Week 1", value: 3200),
                ChartDataPoint(label: "Week 2", value: 4500),
                ChartDataPoint(label: "Week 3", value: 5800),
                ChartDataPoint(label: "Week 4", value: 6200)
            ]
        case .year:
            return [
                ChartDataPoint(label: "Jan", value: 12000),
                ChartDataPoint(label: "Feb", value: 15000),
                ChartDataPoint(label: "Mar", value: 18000),
                ChartDataPoint(label: "Apr", value: 14000),
                ChartDataPoint(label: "May", value: 19000),
                ChartDataPoint(label: "Jun", value: 21000),
                ChartDataPoint(label: "Jul", value: 17000),
                ChartDataPoint(label: "Aug", value: 23000),
                ChartDataPoint(label: "Sep", value: 19500),
                ChartDataPoint(label: "Oct", value: 22000),
                ChartDataPoint(label: "Nov", value: 24000),
                ChartDataPoint(label: "Dec", value: 26000)
            ]
        case .all:
            return [
                ChartDataPoint(label: "2024 Q1", value: 35000),
                ChartDataPoint(label: "2024 Q2", value: 48000),
                ChartDataPoint(label: "2024 Q3", value: 62000),
                ChartDataPoint(label: "2024 Q4", value: 71000),
                ChartDataPoint(label: "2025 Q1", value: 85000),
                ChartDataPoint(label: "2025 Q2", value: 92000)
            ]
        }
    }
    
    var body: some View {
        Chart {
            ForEach(sampleData) { dataPoint in
                BarMark(
                    x: .value("Period", dataPoint.label),
                    y: .value("Value", dataPoint.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.Colors.accent, Theme.Colors.accent.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(4)
            }
        }
        .chartXAxis {
            AxisMarks(preset: .aligned, position: .bottom) { value in
                AxisValueLabel()
                    .font(Theme.Typography.tiny)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                    .foregroundStyle(Theme.Colors.border)
                AxisValueLabel()
                    .font(Theme.Typography.tiny)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundColor(Theme.Colors.accent)
                .frame(width: 24)
            
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textPrimary)
        }
        .padding(Theme.Spacing.sm)
        .terminalCard()
    }
}

struct TopGigRow: View {
    let rank: Int
    let title: String
    let earnings: String
    let orders: Int
    
    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return Theme.Colors.textSecondary
        }
    }
    
    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Text("\(rank)")
                    .font(Theme.Typography.body.weight(.bold))
                    .foregroundColor(rankColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("\(orders) order(s)")
                    .font(Theme.Typography.tiny)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
            
            Text(earnings)
                .font(Theme.Typography.body.weight(.bold))
                .foregroundColor(Theme.Colors.accent)
        }
        .padding(Theme.Spacing.sm)
        .terminalCard()
    }
}

// MARK: - Supporting Types

enum AnalyticsPeriod: String, CaseIterable {
    case week = "WEEK"
    case month = "MONTH"
    case year = "YEAR"
    case all = "ALL TIME"
}

enum AnalyticsMetric: String, CaseIterable {
    case earnings = "Earnings"
    case projects = "Projects"
    case views = "Views"
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

#Preview {
    NavigationStack {
        AnalyticsView()
    }
}
