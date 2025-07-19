//
//  SemanticColor.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/19/25.
//

struct SemanticColor {
    let background_base = ColorPalette.gray30
    let background_surface = ColorPalette.white
    let background_elevated = ColorPalette.white
    let background_onSurface = ColorPalette.gray30
    let background_onElevated = ColorPalette.gray30
    let background_surfaceInversion = ColorPalette.gray900
    let background_dimmed = ColorPalette.black.opacity(0.7)
    
    let fill_primary = ColorPalette.gray100
    let fill_secondary = ColorPalette.gray50
    let fill_tertiary = ColorPalette.gray30
    let fill_disabled = ColorPalette.gray50
    let fill_primaryInversion = ColorPalette.gray950
    let fill_secondaryInversion = ColorPalette.gray700
    let fill_white = ColorPalette.white
    
    let border_primary = ColorPalette.gray100
    let border_secondary = ColorPalette.gray150
    let border_strong = ColorPalette.gray950
    let border_disabled = ColorPalette.gray100
    let border_active = ColorPalette.gray300
    
    let divider_1px = ColorPalette.gray50
    let divider_1pxStrong = ColorPalette.gray100
    let divider_10px = ColorPalette.gray50
    
    let text_strong = ColorPalette.gray950
    let text_primary = ColorPalette.gray900
    let text_secondary = ColorPalette.gray700
    let text_tertiary = ColorPalette.gray400
    let text_disabled = ColorPalette.gray300
    let text_strongInverse = ColorPalette.white
    
    let icon_strong = ColorPalette.gray950
    let icon_primary = ColorPalette.gray800
    let icon_secondary = ColorPalette.gray700
    let icon_tertiary = ColorPalette.gray400
    let icon_disabled = ColorPalette.gray300
    let icon_strongInverse = ColorPalette.white
    
    let state_positive_primary = ColorPalette.green500
    let state_positive_border = ColorPalette.green150
    let state_positive_background = ColorPalette.green50
    let state_negative_primary = ColorPalette.red500
    let state_negative_border = ColorPalette.red150
    let state_negative_background = ColorPalette.red50
}
