//
//  PathStyle.swift
//  Scalar2D
//
//  Created by Glenn Howes on 1/16/19.
//  Copyright © 2019 Generally Helpful Software. All rights reserved.
//

import Foundation

public enum LineCap : InheritableProperty, Equatable
{
    case inherit
    case initial
    case normal
    
    case butt
    case round
    case square
    
    init?(name : String)
    {
        switch name
        {
            case "inherit":
                self = .inherit
            case "initial":
                self = .initial
            case "butt":
                self = .butt
            case "round":
                self =  .round
            case "square":
                self = .square
            default:
                return nil
        }
    }
    
    public var useInitial: Bool
    {
        return  .initial == self
    }
    
    public var useInherited: Bool
    {
        return  .inherit == self
    }
    
    public var useNormal: Bool
    {
        return  .normal == self
    }
}

public enum LineJoin : InheritableProperty, Equatable
{
    case inherit
    case initial
    case normal
    
    case bevel
    case miter
    case miter_clip
    case round
    
    init?(name : String)
    {
        switch name
        {
            case "inherit":
                self = .inherit
            case "initial":
                self = .initial
            case "bevel":
                self = .bevel
            case "miter":
                self =  .miter
            case "miter-clip":
                self = .miter_clip
            case "round":
                self = .round
            default:
                return nil
        }
    }
    
    public var useInitial: Bool
    {
        return  .initial == self
    }
    
    public var useInherited: Bool
    {
        return  .inherit == self
    }
    
    public var useNormal: Bool
    {
        return  .normal == self
    }
}
